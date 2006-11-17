From: Jeff Garzik <jeff@garzik.org>
Subject: Re: driver support for Chelsio T210 10Gb ethernet in 2.6.x
Date: Fri, 17 Nov 2006 15:30:57 -0500
Message-ID: <455E1C01.8000603@garzik.org>
References: <8A71B368A89016469F72CD08050AD334DA4851@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933642AbWKQUbA@vger.kernel.org>
To: Felix Marti <felix@chelsio.com>
In-Reply-To: <8A71B368A89016469F72CD08050AD334DA4851@maui.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Felix Marti wrote:
> Jeff, as indicated by Chris, the driver that is in the kernel is for
> N110 and N210. So far, we have not received any customer complaints
> regarding bugs in the driver and thus it has not been updated in a long
> time. If you feel like there are some missing features/bug fixes, I'd be
> glad to spend some time on it.
> 
> However, Chris's initial request is regarding support for T210. As you
> indicate, the T210 product is a superset of N110/N210 and i.e. supports
> TOE. Since the T210 board features additional pieces of hardware, these
> must be initialized (i.e. memory controllers and TCAM) even if the board
> is to be used as a NIC only. If the kernel developers are okay with
> these additional initialization procedures we could update the driver to
> support N as well as T based products, in NIC mode only, of course ;)


I'd welcome support for NIC mode, so, sure...

	Jeff
