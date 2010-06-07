From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: in_dev->refcnt and dev->refcnt
Date: Mon, 7 Jun 2010 14:50:28 +0530
Message-ID: <AANLkTinijGlJRnqhcEbXhc84MXc62gbshxvTa6JeXo2K@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49891 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755995Ab0FGJU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 05:20:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there any relation between in_dev->refcnt and dev->refcnt ?  . My
question is : if  put or get on one variable affects other ?

-Ratheesh
