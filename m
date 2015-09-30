From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 3/3] RDS-TCP: Set up MSG_MORE and
 MSG_SENDPAGE_NOTLAST as appropriate in rds_tcp_xmit
Date: Wed, 30 Sep 2015 12:00:57 -0400
Message-ID: <20150930160057.GB8111@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
 <4471e1253cbbd917c1b1bd62b5b14844c19a857f.1443569239.git.sowmini.varadhan@oracle.com>
 <560C0632.5060108@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com
To: santosh shilimkar <santosh.shilimkar@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24179 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352AbbI3QBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 12:01:11 -0400
Content-Disposition: inline
In-Reply-To: <560C0632.5060108@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/30/15 08:56), santosh shilimkar wrote:
> Your checkpatch.pl should have complained about commit
> reference in the change-log. You might want to fix that
> for consistency.

It didnt. But ok, I'll fix this nit as well.
