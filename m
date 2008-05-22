From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] make myri10ge_get_firmware_capabilities() static
Date: Thu, 22 May 2008 06:20:45 -0400
Message-ID: <483548FD.30703@pobox.com>
References: <20080519215300.GC17716@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>, Andrew Gallatin <gallatin@myri.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59251 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762016AbYEVKUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:20:55 -0400
In-Reply-To: <20080519215300.GC17716@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch makes the needlessly global 
> myri10ge_get_firmware_capabilities() static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

applied


