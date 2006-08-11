From: Nathan Lynch <ntl@pobox.com>
Subject: Re: [PATCH 2/6] ehea: pHYP interface
Date: Fri, 11 Aug 2006 16:26:49 -0500
Message-ID: <20060811212649.GN3233@localdomain>
References: <44D99F1A.4080905@de.ibm.com> <20060811211915.GL3233@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Klein <tklein@de.ibm.com>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rune.pobox.com ([208.210.124.79]:29075 "EHLO rune.pobox.com")
	by vger.kernel.org with ESMTP id S932284AbWHKV07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 17:26:59 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060811211915.GL3233@localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nathan Lynch wrote:

> Hope all the callers of this function are in non-atomic context (but I
> wasn't able to find any callers?).

Never mind, I somehow missed the users of ehea_hcall_9arg_9ret in this
patch, sorry.
