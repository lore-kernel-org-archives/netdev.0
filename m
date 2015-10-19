From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: add calls to fflush in fdb and mdb
 print functions
Date: Sun, 18 Oct 2015 21:47:39 -0700
Message-ID: <20151018214739.3e4eae51@xeon-e3>
References: <1444945997-55864-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33749 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbbJSEr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 00:47:28 -0400
Received: by pabrc13 with SMTP id rc13so178743114pab.0
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 21:47:28 -0700 (PDT)
In-Reply-To: <1444945997-55864-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2015 14:53:17 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Wilson Kok <wkok@cumulusnetworks.com>
> 
> This patch adds fflush in fdb and mdb print functions
> 
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied
