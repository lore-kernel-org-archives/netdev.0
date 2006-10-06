From: "Bin Zhang" <yangtze31@gmail.com>
Subject: Re: Latest fixes to bcm43xx-d80211 now available as patch to 2.6.18
Date: Fri, 6 Oct 2006 19:40:15 +0200
Message-ID: <51ad2e0d0610061040v3f532e83h96df3d67c379529d@mail.gmail.com>
References: <45259659.9040804@lwfinger.net>
	 <51ad2e0d0610060137n5cc2bf4cna4a4a68ccedd94e@mail.gmail.com>
	 <45268352.7010504@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:44411 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1422783AbWJFRkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 13:40:16 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1159501nfa
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2006 10:40:15 -0700 (PDT)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <45268352.7010504@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/6/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> Bin Zhang wrote:
> >  CC [M]  drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.o
> >  LD [M]  drivers/net/wireless/d80211/bcm43xx/bcm43xx-d80211.o
> >  LD      drivers/net/wireless/built-in.o
> > ld: drivers/net/wireless/d80211/built-in.o: No such file: No such file
> > or directory
> > make[3]: *** [drivers/net/wireless/built-in.o] Error 1
> > make[2]: *** [drivers/net/wireless] Error 2
> > make[1]: *** [drivers/net] Error 2
> > make: *** [drivers] Error 2
>
> Initially I had seen that error, but thought it was fixed. A new version has been uploaded that
> builds correctly from a 'make clean' - please try it.
>

Thanks. It works fine now (2.6.18 + the two patches).

Best regards,
Bin

> Also, please note Johannes Berg's comments regarding the increased interrupt usage for V4 firmware.
>
> Larry
> _______________________________________________
> Bcm43xx-dev mailing list
> Bcm43xx-dev@lists.berlios.de
> https://lists.berlios.de/mailman/listinfo/bcm43xx-dev
>
