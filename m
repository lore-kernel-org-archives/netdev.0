From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 03/21] RDS: Congestion-handling code
Date: Wed, 28 Jan 2009 14:57:01 -0800
Message-ID: <ada7i4fujia.fsf@cisco.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-4-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:10249 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbZA1W5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 17:57:04 -0500
In-Reply-To: <1233022678-9259-4-git-send-email-andy.grover@oracle.com> (Andy
	Grover's message of "Mon, 26 Jan 2009 18:17:40 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +EXPORT_SYMBOL_GPL(rds_cong_map_updated);

What is this being exported to?  AFAICT you are only building a single
RDS module, right?

 - R.
