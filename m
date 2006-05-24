From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [-mm patch] drivers/net/s2io.c: make bus_speed[] static
Date: Wed, 24 May 2006 01:28:40 -0400
Message-ID: <4473EF08.1010709@pobox.com>
References: <20060515005637.00b54560.akpm@osdl.org> <20060516153050.GC5677@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Ananda Raju <ananda.raju@neterion.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:1248 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932516AbWEXF2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 01:28:53 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060516153050.GC5677@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Mon, May 15, 2006 at 12:56:37AM -0700, Andrew Morton wrote:
>> ...
>> Changes since 2.6.17-rc3-mm1:
>> ...
>>  git-netdev-all.patch
>> ...
>>  git trees
>> ...
> 
> 
> This patch makes the needlessly global bus_speed[] static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


