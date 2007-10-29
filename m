From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Configuring the same IP on multiple addresses
Date: Mon, 29 Oct 2007 12:36:19 -0700
Message-ID: <OFF06924F1.9917F90F-ON88257383.006B3289-88257383.006B98D2@us.ibm.com>
References: <47262079.90507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60774 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbXJ2Tgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 15:36:32 -0400
In-Reply-To: <47262079.90507@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote on 10/29/2007 11:03:37 AM:

> So, I am looking for technical reasons why this is permitted.

Vlad,
        Is there a technical reason to disallow it? Rather than
anticipate all the possible uses for a machine, it's, of course,
generally better to restrict only the things you know can't
work, and allow everything else.

                                                        +-DLS

