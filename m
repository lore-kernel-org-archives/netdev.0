From: "Eugene Teo" <eugeneteo@kernel.sg>
Subject: Internet-Draft on Port Randomisation
Date: Tue, 9 Sep 2008 12:07:10 +0800
Message-ID: <28fa9c5e0809082107p7a33dc4fod344fde212e1d710@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eugene Teo" <eteo@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:50314 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbYIIEHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:07:11 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1732363rvb.1
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:07:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has anyone read this Internet-Draft?
http://www.gont.com.ar/drafts/port-randomization/draft-ietf-tsvwg-port-randomization-02.txt

In this memo, there are descriptions of four different ephemeral port
randomisation algorithms (see page 17).

Algo #1 and #2 are simple port randomisation algorithms. Algo #3 is
what we have in Linux. The memo suggested algorithm #4, double-hash
randomisation algorithm, which is an improvement to algo #3 (see page
15).

Does anyone have any thought about the improved algorithm? Is this
worth implementing, given the possible additional overhead that it
has?

Thanks, Eugene
