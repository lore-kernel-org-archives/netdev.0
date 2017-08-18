From: David Howells <dhowells@redhat.com>
Subject: Does the kernel have a function to parse a text IPv6 address?
Date: Fri, 18 Aug 2017 19:32:01 +0100
Message-ID: <30054.1503081121@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751077AbdHRScD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 14:32:03 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 09D8A883C0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 18:32:03 +0000 (UTC)
Content-ID: <30053.1503081121.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does the kernel have a function to parse a text IPv6 address of the form
"x:y:..::z" and put it into a struct sockaddr_in6?

David
