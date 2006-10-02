From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/5] remove TxStartThresh and RxEarlyThresh
Date: Sun, 1 Oct 2006 23:53:12 -0700
Message-ID: <20061001235312.aa2c6d17.akpm@osdl.org>
References: <1159813431.2576.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62347 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932699AbWJBGyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 02:54:02 -0400
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <1159813431.2576.0.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 02 Oct 2006 14:23:51 -0400
Jesse Huang <jesse@icplus.com.tw> wrote:

> For pattern issue need to remove TxStartThresh and RxEarlyThresh.

Please describe this issue more completely.

What are the implications of simply removing this feature?  Presumably that
code was there for a reason..
