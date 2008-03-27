From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch for 2.6.25? 3/3] skge napi->poll() locking bug
Date: Thu, 27 Mar 2008 10:11:42 -0700
Message-ID: <20080327101142.4ad339b9.akpm@linux-foundation.org>
References: <200803270745.m2R7jEUA024166@imap1.linux-foundation.org>
	<47EB91B1.8000307@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mitov@issp.bas.bg, davem@davemloft.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54629 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761865AbYC0RMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 13:12:39 -0400
In-Reply-To: <47EB91B1.8000307@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Mar 2008 08:23:13 -0400 Jeff Garzik <jeff@garzik.org> wrote:

> davem already has this

In which I discover that net-2.6.26 doesn't include net-2.6?

hrm.
