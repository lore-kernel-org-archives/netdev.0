From: bert hubert <ahu@ds9a.nl>
Subject: Re: Major deadlock: unregister_netdevice: waiting for <device> to become free. Usage count = 1
Date: Mon, 27 Dec 2004 00:01:33 +0100
Message-ID: <20041226230133.GA1448@outpost.ds9a.nl>
References: <8A6334DE39BB61513FFBD614@t1mobil.muc.aerasec.de> <A3A6D3E15EE6197D77408F1A@t1mobil.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist USAGI-users <usagi-users@linux-ipv6.org>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Bieringer <pb@bieringer.de>
Content-Disposition: inline
In-Reply-To: <A3A6D3E15EE6197D77408F1A@t1mobil.muc.aerasec.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 26, 2004 at 10:26:28AM +0100, Peter Bieringer wrote:

> >Dec 26 09:59:10 * kernel: unregister_netdevice: waiting for sit_sixxs to
> >become free. Usage count = 1

Happens to me as well with 2.6.10-rc2 Debian sid. Haven't been able to debug
it yet.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
