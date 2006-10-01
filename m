From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3][ATM]: kmalloc to kzalloc patches for drivers/atm
Date: Sun, 01 Oct 2006 12:01:09 -0400
Message-ID: <451FE645.9040309@garzik.org>
References: <200610011517.k91FH5Tv006371@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:64909 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751217AbWJAQBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 12:01:13 -0400
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
In-Reply-To: <200610011517.k91FH5Tv006371@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You also need to mark firestream as 32-bit only, in Kconfig...

(or fix it)


