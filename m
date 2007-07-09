From: Andrew Morton <akpm@linux-foundation.org>
Subject: O_CLOEXEC patches
Date: Mon, 9 Jul 2007 14:54:41 -0700
Message-ID: <20070709145441.4e7d6bd1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39119 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755509AbXGIVzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 17:55:19 -0400
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [207.189.120.55])
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l69LskPc028452
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 14:54:47 -0700
Received: from akpm.corp.google.com (localhost [127.0.0.1])
	by imap1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with SMTP id l69Lsf8E014481
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 14:54:41 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A couple of patches here which affect networking.  Please review...

