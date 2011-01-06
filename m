From: Michael Blizek <michi1@michaelblizek.twilightparadox.com>
Subject: [RFC] Connection oriented routing
Date: Thu, 6 Jan 2011 08:34:08 +0100
Message-ID: <20110106073408.GA2017@michaelblizek.twilightparadox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, chambilkethakur@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from michaelblizek.twilightparadox.com ([193.238.157.55]:38855 "EHLO
	michaelblizek.twilightparadox.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751241Ab1AFHxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 02:53:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I am implementing a connection oriented source routed layer 3/4 protocol for
zero administration (community/mesh) networks. It takes care of things like
fair bandwidth allocation and has higher security/privacy so that it can really
run without administration. It is basically running, but not entirely stable
and with some loose ends. You can find some more info here:
http://michaelblizek.twilightparadox.com/projects/cor/index.html

git repo (based on 2.6.28):
http://repo.or.cz/w/cor.git?a=tree

My 2 previous queries to netdev:
http://article.gmane.org/gmane.linux.network/80232
http://article.gmane.org/gmane.linux.network/144915

	-Michi

