//
//  VkServiceScripts.swift
//  AddMusicVK
//
//  Created by Анастасия Ступникова on 25.05.2022.
//

enum VkServiceScripts {
    static let enterLogin = """
    (() => {
        document.getElementsByName("login")[0].value = "FIELD_VALUE";
        document.getElementsByName("login")[0].dispatchEvent(new Event('input', {
            bubbles: true,
            cancelable: true,
        }));
        
        setTimeout(() => {
            document.getElementsByClassName("vkc__Button__primary")[0].click()
        }, 0);
    })();
    """
    
    static let enterPassword = """
    (() => {
        document.getElementsByName("password")[0].value = "FIELD_VALUE";
        document.getElementsByName("password")[0].dispatchEvent(new Event('input', {
            bubbles: true,
            cancelable: true,
        }));
        
        setTimeout(() => {
            document.getElementsByClassName("vkc__Button__primary")[0].click()
        }, 0);
    })();
    """
    
    static let enterCode = """
    (() => {
        document.getElementsByName("token")[0].dispatchEvent(new Event('focus', {
            bubbles: true,
            cancelable: true,
        }));
    
        document.getElementsByName("token")[0].value = "FIELD_VALUE"
        document.getElementsByName("token")[0].dispatchEvent(new Event('input', {
            bubbles: true,
            cancelable: true,
        }));
        
        setTimeout(() => {
            document.getElementsByClassName("vkc__Button__primary")[0].click()
        }, 0);
    })();
    """
    
    static let enterCaptcha = """
    (() => {
        document.querySelector('.vkc__Captcha__container input').value = "FIELD_VALUE";
        document.querySelector('.vkc__Captcha__container input').dispatchEvent(new Event('input', {
            bubbles: true,
            cancelable: true,
        }));
        
        setTimeout(() => {
            document.querySelector('.vkc__Captcha__container button').click()
        }, 0);
    })();
    """
    
    static let signInScript = """
    (() => {
        let pageState = {
            isCaptchaPresented: false,
            isLoginFormLoaded: false,
            isPasswordFormLoaded: false,
            isCodeFormLoaded: false,
            isErrorPresented: false,
            isSignedIn: false,
        };
    
        let sendMessage = (state) => {
            let message = {
                state: state,
            };
            
            window.webkit.messageHandlers.iOSObserver.postMessage(message);
        };
        
        let sendMessageCaptcha = (captchaUrl) => {
            let message = {
                state: "captchaPresented",
                captchaUrl: captchaUrl,
            };
            
            window.webkit.messageHandlers.iOSObserver.postMessage(message);
        };
        
        let checkPageState = () => {
            let isLoginFormLoaded = typeof document.getElementsByName("login")[0] !== 'undefined';
            let isPasswordFormLoaded = typeof document.getElementsByName("password")[0] !== 'undefined';
            let isCodeFormLoaded = typeof document.getElementsByName("token")[0] !== 'undefined';
            let isErrorPresented = typeof document.getElementsByClassName("vkc__TextField__errorIcon")[0] !== 'undefined';
            let isSignedIn = typeof document.getElementsByClassName("owner_panel")[0] !== 'undefined';
            
            let captchaImg = document.getElementsByClassName("vkc__Captcha__image")[0];
            let isCaptchaPresented = typeof captchaImg !== 'undefined';
    
            if(isCaptchaPresented && isCaptchaPresented != pageState.isCaptchaPresented) {
                sendMessageCaptcha(captchaImg.src);
            }
    
            if(isLoginFormLoaded && isLoginFormLoaded != pageState.isLoginFormLoaded) {
                sendMessage("loginFormLoaded");
            }
            
            if(isPasswordFormLoaded && isPasswordFormLoaded != pageState.isPasswordFormLoaded) {
                sendMessage("passwordFormLoaded");
            }
            
            if(isCodeFormLoaded && isCodeFormLoaded != pageState.isCodeFormLoaded) {
                sendMessage("codeFormLoaded");
            }
            
            if(isErrorPresented && isErrorPresented != pageState.isErrorPresented) {
                sendMessage("errorPresented");
            }
            
            if(isSignedIn && isSignedIn != pageState.isSignedIn) {
                sendMessage("successSignedIn");
            }
            
            pageState.isCaptchaPresented = isCaptchaPresented;
            pageState.isLoginFormLoaded = isLoginFormLoaded;
            pageState.isPasswordFormLoaded = isPasswordFormLoaded;
            pageState.isCodeFormLoaded = isCodeFormLoaded;
            pageState.isErrorPresented = isErrorPresented;
            pageState.isSignedIn = isSignedIn;
        };
        
        let mutationObserver = new window.WebKitMutationObserver((mutationList) => {
            checkPageState();
        });

        mutationObserver.observe(document, {
            childList: true,
            attributes: true,
            subtree: true
        });
        
        checkPageState();
    })();
    """
    
    static let musicScript = """
    let commandAddTrack = (trackID) => {
        let sendMessage = (state) => {
            let message = {
                state: state,
            };
            
            window.webkit.messageHandlers.iOSObserver.postMessage(message);
        };
        
        let trackElement = document.querySelector('div[data-id="' + trackID + '"] .ai_menu_toggle_button');
        if(!trackElement) {
            sendMessage("trackNotFound");
            return;
        }
        
        trackElement.click();
        
        setTimeout(() => {
            let addTrackElement = document.getElementsByClassName('ContextMenu__listLink')[0]
            if(!addTrackElement) {
                sendMessage("addTrackButtonNotFound");
                return;
            }
            
            addTrackElement.click();
            setTimeout(() => {
                let cancelElement = document.getElementsByClassName('ModalMenu__cancel')[0];
                if(!cancelElement) {
                    sendMessage("cancelElementNotFound");
                    return;
                }
                
                cancelElement.click();
                
                setTimeout(() => {
                    sendMessage("trackAddedSuccessfully");
                }, 1000);
            });
        }, 0);
    };
    
    (() => {
        let pageState = {
            isUserIDGot: false,
            isSignedIn: true,
            isMusicPageLoaded: false,
            isAllMusicLoaded: false,
        };

        let sendMessage = (state) => {
            let message = {
                state: state,
            };
            
            window.webkit.messageHandlers.iOSObserver.postMessage(message);
        };
        
        let sendMessageUserID = (userID) => {
            let message = {
                state: "profilePageLoaded",
                userID: userID,
            };
            
            window.webkit.messageHandlers.iOSObserver.postMessage(message);
        };
        
        let sendMessageMoreTracksLoading = (tracksNumber) => {
            let message = {
                state: "moreTracksLoading",
                tracksNumber: tracksNumber,
            };
            
            window.webkit.messageHandlers.iOSObserver.postMessage(message);
        };
        
        let sendMessageAllMusicLoaded = (tracksList) => {
            let message = {
                state: "allMusicLoaded",
                tracksList: tracksList,
            };
            
            window.webkit.messageHandlers.iOSObserver.postMessage(message);
        };
        
        let doScroll = () => {
            window.scroll(0, window.window.scrollGetY() + 10000);
        };
        
        let parseUserID = () => {
            let element = document.getElementsByClassName("ProfileButton")[1];
            if(!element) { return null; }
            
            let href = element.href;
            if(!href) { return null; }
            
            let slashSplitResult = href.split("/")[3];
            if(!slashSplitResult) { return null; }
            
            let questionSplitResult = slashSplitResult.split("?")[0];
            if(!questionSplitResult) { return null; }
            
            let userID = questionSplitResult.split("gifts")[1];
            if(!userID) { return null; }
            
            return userID;
        };
        
        let checkPageState = () => {
            let isSignedIn = typeof document.getElementsByClassName("owner_panel")[0] !== 'undefined';
            
            let someButton = typeof document.getElementsByClassName("Btn_theme_regular")[1];
            let userID = parseUserID();
            let isUserIDGot = userID !== null;
            
            let tracksContainer = document.getElementsByClassName("AudioPlaylistRoot AudioBlock__content")[0];
            
            let tracksNumber = 0;
            if(tracksContainer) {
                tracksNumber = tracksContainer.getElementsByClassName("audio_item").length;
            }
            
            let isMusicPageLoaded = tracksNumber > 0;

            let canLoadMore = document.getElementsByClassName("show_more_wrap").length > 0 || document.getElementById("show_more_wrap") !== null;
            
            let isAllMusicLoaded = isMusicPageLoaded && !canLoadMore;

            if(isUserIDGot && isUserIDGot != pageState.isUserIDGot) {
                sendMessageUserID(userID);
            }
            
            if(!isSignedIn && isSignedIn != pageState.isSignedIn) {
                sendMessage("notSignedIn");
            }
            
            if(isMusicPageLoaded && isMusicPageLoaded != pageState.isMusicPageLoaded) {
                sendMessage("musicPageLoaded");
            }
            
            if(canLoadMore) {
                doScroll();
                sendMessageMoreTracksLoading(tracksNumber);
            }
            
            if(isAllMusicLoaded && isAllMusicLoaded != pageState.isAllMusicLoaded) {
                let tracksElements = tracksContainer.getElementsByClassName("audio_item");
                let tracksList = [];
                for(let element of tracksElements) {
                    tracksList.push({
                        name: element.getElementsByClassName('ai_title')[0].innerText,
                        artist: element.getElementsByClassName('ai_artist')[0].innerText,
                        id: element.getAttribute("data-id"),
                    });
                }
                
                sendMessageAllMusicLoaded(tracksList);
            }
            
            pageState.isUserIDGot = isUserIDGot;
            pageState.isSignedIn = isSignedIn;
            pageState.isMusicPageLoaded = isMusicPageLoaded;
            pageState.isAllMusicLoaded = isAllMusicLoaded;
        };
        
        let mutationObserver = new window.WebKitMutationObserver((mutationList) => {
            checkPageState();
        });

        mutationObserver.observe(document, {
            childList: true,
            attributes: true,
            subtree: true
        });
        
        checkPageState();
    })();
    """
}
