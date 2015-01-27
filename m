From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next V1 04/11] net/mlx4_core: Adjust command
 timeouts to conform to the firmware spec
Date: Tue, 27 Jan 2015 14:30:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD3EAA@AcuExch.aculab.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
 <1422367089-13419-5-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"Jack Morgenstein" <jackm@dev.mellanox.co.il>
To: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:63085 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464AbbA0Oan convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 09:30:43 -0500
In-Reply-To: <1422367089-13419-5-git-send-email-amirv@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai
> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> The firmware spec states that the timeout for all commands should be 60 seconds.

Hmmm... 60 seconds seems a long time to wait for a device to do something.

I'll have given up and reset the machine before that expires.

	David
