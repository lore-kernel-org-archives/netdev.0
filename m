From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: 2.6.12 Performance problems
Date: Sat, 27 Aug 2005 15:19:05 +0400
Message-ID: <20050827111904.GA6484@tentacle.sectorb.msk.ru>
References: <430D4E6D.1090200@candelatech.com> <20050825060843.15874.qmail@web33311.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Ben Greear <greearb@candelatech.com>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030353AbVH0LTH@vger.kernel.org>
To: Danial Thom <danial_thom@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20050825060843.15874.qmail@web33311.mail.mud.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 24, 2005 at 11:08:43PM -0700, Danial Thom wrote:
> If your test is still set up, try compiling
> something large while doing the test. The drops
> go through the roof in my tests.
> 
Couldn't this happen because ksoftirqd by default 
has a nice value of 19?

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 
