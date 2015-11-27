From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: tty,net: use-after-free in x25_asy_open_tty
Date: Thu, 26 Nov 2015 23:27:06 -0500
Message-ID: <5657DB9A.1040103@oracle.com>
References: <564F26A5.4050905@oracle.com>
 <564F7B94.3060405@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter Hurley <peter@hurleysoftware.com>,
	gregkh@linuxfoundation.org, Jiri Slaby <jslaby@suse.cz>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564F7B94.3060405@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/20/2015 02:59 PM, Peter Hurley wrote:
> Thanks for the report, Sasha.
> Would you please test the patch below?

Fixes it for me, thanks!


Thanks,
Sasha
