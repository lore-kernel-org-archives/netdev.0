From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: e1000 driver problem with Intel Pro/1000 MT adapter
Date: Sat, 4 Dec 2004 13:03:28 +0100
Message-ID: <20041204120328.GA1191@electric-eye.fr.zoreil.com>
References: <200412032325.iB3NPdG04693@xos037.xos.nl> <20041204005946.GA26654@electric-eye.fr.zoreil.com> <20041204021444.A5058@xos037.xos.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jos Vos <jos@xos.nl>
Content-Disposition: inline
In-Reply-To: <20041204021444.A5058@xos037.xos.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jos Vos <jos@xos.nl> :
[...]
> Well, I could do that, but the idea was to use this in a RHEL3
> system, so ...

1 - Imho people at RedHat/wherever need more details (chipset, mobo,
    dmesg, lspci -vx, 2.4.21 savor ?).
2 - Testing recent 2.6.x will provide a different datapoint and a wider
    review: a few people use e1000 for interested things here but they
    do not necessarily have the resources to help with a specific vendor
    released kernel. The vendor can use the datapoint though.
3 - Comparing lspci and dmesg output for the different failure may give
    an hint.

--
Ueimor
