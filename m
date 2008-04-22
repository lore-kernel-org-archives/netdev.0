From: "Rui T. Matos" <rmatos@hng.av.it.pt>
Subject: [PATCH] libnl: Add tcindex classifier
Date: Tue, 22 Apr 2008 16:32:45 +0100
Message-ID: <731.123137711798$1208882081@news.gmane.org>
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:44906 "EHLO av.it.pt"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753253AbYDVQcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2008 12:32:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a request for comments patch to add support for the tcindex classifier
to libnl.

It lacks support for the police and action attributes and the dump callbacks
aren't implementend since I don't know what to output exactly on each one.

Please comment.

Thanks,
Rui
 


