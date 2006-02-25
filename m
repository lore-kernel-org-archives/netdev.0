From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2.6 patch] make UNIX a bool
Date: Sat, 25 Feb 2006 09:13:08 -0800
Message-ID: <44009024.5050105@osdl.org>
References: <20060225160150.GX3674@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932646AbWBYRQ0@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060225160150.GX3674@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> CONFIG_UNIX=m doesn't make much sense.
>
>
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>
>
>   
Why? You can build unix domain sockets as a loadable module and
it runs fine (or it did last I tried). Whether that makes sense from a 
distribution point of
view, because everybody wants it, is another story.
