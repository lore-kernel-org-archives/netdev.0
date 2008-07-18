From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: [patch] WAN: add drivers dslp and sdfe4-cfg
Date: Fri, 18 Jul 2008 12:16:35 +0300
Message-ID: <ca0148c30807180216h422c35e6l640fdad458f3587a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.237]:44975 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756556AbYGRJQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 05:16:37 -0400
Received: by qb-out-0506.google.com with SMTP id p36so1208229qba.17
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 02:16:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The drivers dslp and sdfe4-cfg support G.SHDSL PCI104 card DSLP.
The following patch is on top of linux-next July 17:
http://groups.google.com/group/pcidriver/web/dslp.patch
