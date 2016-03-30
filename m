From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [net PATCH v2] i40e/i40evf: Limit TSO to 7 descriptors for
 payload instead of 8 per packet
Date: Wed, 30 Mar 2016 19:51:53 -0400
Message-ID: <20160330235153.GM27540@oracle.com>
References: <20160330231116.12643.59554.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	alexander.duyck@gmail.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34470 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbcC3XwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 19:52:09 -0400
Content-Disposition: inline
In-Reply-To: <20160330231116.12643.59554.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Yes, this fixes it for me too!

Tested-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
