From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [PATCH 03/21] RDS: Congestion-handling code
Date: Tue, 27 Jan 2009 11:15:05 -0800
Message-ID: <c0a09e5c0901271115ucde234eldd243f3786a4b011@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	 <1233022678-9259-4-git-send-email-andy.grover@oracle.com>
	 <20090126194820.41cdb7f5@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy Grover <andy.grover@oracle.com>, rdreier@cisco.com,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:42651 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316AbZA0TPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 14:15:07 -0500
Received: by rn-out-0910.google.com with SMTP id k40so2258248rnd.17
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 11:15:05 -0800 (PST)
In-Reply-To: <20090126194820.41cdb7f5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 7:48 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> So this is starting to look like another "Oracle special" like AIO
> and HugeTLB. That has lots of caveat restrictions on the application.

Yep it's a datacenter-centric protocol.

Regards -- Andy
