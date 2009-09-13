From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 5/5] Updating documentation accordingly
Date: Sun, 13 Sep 2009 20:50:50 +0200
Message-ID: <20090913185050.GA7475@gerrit.erg.abdn.ac.uk>
References: <4AA6A26A.6080808@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54286 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754378AbZIMSux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Sep 2009 14:50:53 -0400
Content-Disposition: inline
In-Reply-To: <4AA6A26A.6080808@embedded.ufcg.edu.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| Updating documentation accordingly

+/* As defined at section 8.6.1. of RFC 4342 */
 #define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH	28
+/* Specified on section 8.7. of CCID4 draft */
 #define TFRC_DROP_OPT_MAX_LENGTH		84
Need to update the references to CCID4 draft with RFC 5622. See also 4/5.

It would be more helpful to include the documentation for structs with
the patches that use these structs.
