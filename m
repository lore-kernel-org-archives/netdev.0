From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6.15-rc1] VFS: file-max limit 400490 reached
Date: Sat, 12 Nov 2005 00:34:44 -0500
Message-ID: <43757EF4.1060600@pobox.com>
References: <43757D18.9090109@pobox.com> <20051112053052.GA1210@taniwha.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932138AbVKLFer@vger.kernel.org>
To: Chris Wedgwood <cw@f00f.org>
In-Reply-To: <20051112053052.GA1210@taniwha.stupidest.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Wedgwood wrote:
> On Sat, Nov 12, 2005 at 12:26:48AM -0500, Jeff Garzik wrote:
> 
> 
>>	VFS: file-max limit 400490 reached
> 
> 
> does lsof show anything useful?

Alas, no.  [from memory, I've since rebooted]

lsof | wc -l
808
