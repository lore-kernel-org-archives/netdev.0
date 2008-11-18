From: "Subrahmanya, Chaithrika" <chaithrika@ti.com>
Subject: Support for ET1011C PHY using Phylib
Date: Tue, 18 Nov 2008 11:51:48 +0530
Message-ID: <EAF47CD23C76F840A9E7FCE10091EFAB02932A8FBC@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:52455 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761AbYKRGV4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 01:21:56 -0500
Received: from dbdp20.itg.ti.com ([172.24.170.38])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id mAI6Ln2R031611
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 00:21:55 -0600
Received: from dbde71.ent.ti.com (localhost [127.0.0.1])
	by dbdp20.itg.ti.com (8.13.8/8.13.8) with ESMTP id mAI6Lmlr026410
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 11:51:49 +0530 (IST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am planning to submit the patches for ET1011C PHY present on our board.  Phylib will be used for this purpose.
IBM newemac also supports ET1011C PHY but wondering why phylib has not been used? 
Is anybody (who can test this on IBM emac) planning to change the ibm_newemac driver to make it phylib compatible? 

Chaithrika