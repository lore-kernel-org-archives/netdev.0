From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: ath: Unable to reset channel (2412 MHz), reset status -5
Date: Tue, 19 Jul 2011 11:55:55 +0530
Message-ID: <CAD2nsn12vOXv-msWR+GF7edz3Q26P-pb4H-SO4rf2RHjC7mG+w@mail.gmail.com>
References: <4E252076.1050309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E252076.1050309@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 19, 2011 at 11:43 AM, Justin P. Mattock
<justinmattock@gmail.com> wrote:
> seems with the latest Mainline I am getting the ath9k carpping out after a
> while of streaming(dmesg below)..:
> http://fpaste.org/D7wM/
>
> will try a bisect if I have the time..

I will try to recreate here with 3.0.0-rc7-wl, we can get more
information by ath9k debug=0xffffffff.
thanks.

-- 
shafi
