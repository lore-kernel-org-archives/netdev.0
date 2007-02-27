From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] myri10ge: workaround buggy adopted firmwares
Date: Tue, 27 Feb 2007 04:16:57 -0500
Message-ID: <45E3F709.7020502@garzik.org>
References: <45DC7B8C.9070501@myri.com> <45DC7BCD.1070709@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47391 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161070AbXB0JQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:16:58 -0500
In-Reply-To: <45DC7BCD.1070709@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Work around a bug which occurs when adopting firmware versions
> 1.4.4 though 1.4.11 where broadcasts are filtered as if they
> were multicasts.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |   27 +++++++++++++++++++++++----
>  1 file changed, 23 insertions(+), 4 deletions(-)

applied


