From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: odd behavior with r8169 and pcap
Date: Tue, 30 Nov 2004 01:21:27 +0100
Message-ID: <20041130002127.GC3880@electric-eye.fr.zoreil.com>
References: <1101751909.2291.21.camel@tux.hq.axian.com> <20041129210213.GA3880@electric-eye.fr.zoreil.com> <1101766059.3382.57.camel@tux.hq.axian.com> <20041129231800.GB3880@electric-eye.fr.zoreil.com> <1101772869.3382.101.camel@tux.hq.axian.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Terry Griffin <terryg@axian.com>
Content-Disposition: inline
In-Reply-To: <1101772869.3382.101.camel@tux.hq.axian.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Terry Griffin <terryg@axian.com> :
[...]
> Passing acpi=off did the trick. Throughput is at the higher rate
> with or without pcap monitoring. I did not have to change any BIOS
> settings.

As a longer term solution, something can surely be extracted from
the acpi tables of your computer. See
http://forums.gentoo.org/viewtopic.php?t=122145%22%22 for an intro.

--
Ueimor
