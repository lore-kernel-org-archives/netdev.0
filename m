From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH v3] vxge: Use time_before()
Date: Mon, 19 May 2014 22:56:00 +0200
Message-ID: <1400532961-7842-1-git-send-email-manuel.schoelling@gmx.de>
References: <1400520928.30820.23.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, joe@perches.com
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:64167 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbaESU4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 16:56:22 -0400
In-Reply-To: <1400520928.30820.23.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your hints. I tried to incorporate your points into this new version.
