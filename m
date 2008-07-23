From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: delayed ack timer, slow start and LRO
Date: Wed, 23 Jul 2008 12:41:52 +0200
Message-ID: <94a7e9f304c51cd53320ad8ec923d496@localhost>
References: <488659A6.5030703@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: jean-pascal billaud <billaud@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:36553 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751222AbYGWLCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 07:02:04 -0400
In-Reply-To: <488659A6.5030703@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 22 Jul 2008 15:05:26 -0700, jean-pascal billaud

<billaud@vmware.com> wrote:



> I have a question related to the interaction between the delayed ack

> timer, slow start and LRO.



AFAIK, delayed ACKs are disabled in slow start phase.



Hagen





