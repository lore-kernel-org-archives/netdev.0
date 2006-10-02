From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/5] Fix TX Pause bug (reset_tx, intr_handler)
Date: Sun, 1 Oct 2006 23:53:38 -0700
Message-ID: <20061001235338.566f4a67.akpm@osdl.org>
References: <1159813476.2576.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12428 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932696AbWJBGyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 02:54:46 -0400
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <1159813476.2576.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 02 Oct 2006 14:24:36 -0400
Jesse Huang <jesse@icplus.com.tw> wrote:

> Fix TX Pause bug (reset_tx, intr_handler)

Please describe this bug more completely.    How does this patch solve it?
