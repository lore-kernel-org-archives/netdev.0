From: "Karl Meyer" <adhocrocker@gmail.com>
Subject: Re: PROBLEM: 2.6.23-rc "NETDEV WATCHDOG: eth0: transmit timed out"
Date: Sat, 1 Sep 2007 21:24:36 +0200
Message-ID: <be1b757c0709011224tafebaaby697d03ab5377e20f@mail.gmail.com>
References: <be1b757c0708130435y689b9dd8raf9ac9f9c0fcc976@mail.gmail.com>
	 <20070813165821.GA19356@electric-eye.fr.zoreil.com>
	 <be1b757c0708131027v5c57822as2d9bd3190fd19b71@mail.gmail.com>
	 <20070814070901.GA14693@electric-eye.fr.zoreil.com>
	 <be1b757c0708141425qd887581n3922702b84a21758@mail.gmail.com>
	 <20070814224629.GB3495@electric-eye.fr.zoreil.com>
	 <20070816141122.GA6625@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757286AbXIATYw@vger.kernel.org>
In-Reply-To: <20070816141122.GA6625@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is what happened today:

Sep  1 21:08:01 frege NETDEV WATCHDOG: eth0: transmit timed out
frege ~ # uname -r
2.6.22.5-cfs-v20.5


2007/8/16, Francois Romieu <romieu@fr.zoreil.com>:
> (please do not remove the netdev Cc:)
>
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> > If it does not work I'll dissect 0e4851502f846b13b29b7f88f1250c980d57e944
> > tomorrow.
>
> You will find a tgz archive in attachment which contains a serie of patches
> (0001-... to 0005-...) to walk from 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2
> to 0e4851502f846b13b29b7f88f1250c980d57e944 in smaller steps.
>
> Please apply 0001 on top of 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2. If it
> still works, apply 0002 on top of 0001, etc.
>
> --
> Ueimor
>
>
