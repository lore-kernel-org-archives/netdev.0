From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10201] New: Yum update of Kernel broke sis900
	ethernet driver
Date: Thu, 13 Mar 2008 11:37:35 +0000
Message-ID: <20080313113735.GA4930@ff.dom.local>
References: <20080308155052.81cf3c8b.akpm@linux-foundation.org> <20080311091928.GA5765@ff.dom.local> <20080313110312.GA4764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Dan McNaul <dmcnaul@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:22112 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbYCMLgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:36:04 -0400
Received: by fk-out-0910.google.com with SMTP id z23so3321903fkz.5
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 04:36:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080313110312.GA4764@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2008 at 11:03:12AM +0000, Jarek Poplawski wrote:
...
> Dan, you don't have HW (MAC) address set on your card, and it's
> verified since 2.6.23.

Actually: verified before open since 2.6.24.

Jarek P.
