From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: make ss --help output to stdout
Date: Sat, 26 Dec 2009 10:05:49 -0800
Message-ID: <20091226100549.2477b273@nehalam>
References: <20091207121236.GA15104@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 545008@bugs.debian.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55764 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483AbZLZSG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 13:06:27 -0500
In-Reply-To: <20091207121236.GA15104@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Dec 2009 13:12:36 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> Peter Palfrader said in http://bugs.debian.org/545008 that
> "--help output, if explicitly requested, should go to stdout, not stderr."
> which this patch fixes.
> 
> Additionally, the exit code was adjusted to success if help was
> explicitly requested.
> 
> (Syntax error still outputs to stderr and has the same exit code.)

ok, applied

-- 
