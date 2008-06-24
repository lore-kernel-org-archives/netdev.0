From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: [PATCH v1.2.31] wan: add driver retina
Date: Tue, 24 Jun 2008 13:35:02 +0300
Message-ID: <ca0148c30806240335t799ab518o2f7589f6d3282787@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:9864 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820AbYFXKfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 06:35:03 -0400
Received: by yx-out-2324.google.com with SMTP id 31so494338yxl.1
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 03:35:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch is on top of linux-next June 24:
http://pcidriver.googlegroups.com/web/retina-1.2.31.patch?hl=en&gda=IAodQEQAAAD13nxGN0cierCNeIeJfDX5xXkFPvbRgqL6oDt-R_zhlWG1qiJ7UbTIup-M2XPURDSCRcGQDyno6jchG3K2xOQpIvUJau0VvnTEe9ncJ6VTfQ&gsc=eDZaJAsAAADBvYu52m-YgWqvwRZy0wen

Change log:
Fixed ETH_ZLEN minimal packet size
Added mmap(2) interface description
