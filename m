From: Ravi Aysola <ravi.mlists@gmail.com>
Subject: network namespace and DNS lookups
Date: Tue, 18 Dec 2012 10:09:13 -0500
Message-ID: <CAFaHj6GVgDf2QXUWyaKYnvOqLJRjG+kA32eEk5psPkmc-RPY1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:39682 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076Ab2LRPRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 10:17:07 -0500
Received: by mail-wg0-f43.google.com with SMTP id e12so363423wge.22
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 07:17:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has there been any work in any of the recent kernels to limit the DNS lookup
to a particular network namespace?  Do we have any facility to specify the
DNS resolvers on network namespace basis (such as /etc/ns/resolv.conf)?

thank you
ravi/
