From: Patrick McHardy <kaber@trash.net>
Subject: Re: net 2.6.16-rc1: multiple ipv6 failures
Date: Wed, 18 Jan 2006 03:40:30 +0100
Message-ID: <43CDAA9E.7010102@trash.net>
References: <43CDAA58.5000904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964851AbWARCl1@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <43CDAA58.5000904@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> 
> Just moved my firewall/gateway from 2.6.15 to 2.6.16-rc1, and had a
> couple IPv6-related problems really bite me.

The fix just went in Linus' tree ([IPV6]: Preserve procfs IPV6 address
output format).
