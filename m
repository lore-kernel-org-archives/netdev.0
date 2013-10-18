From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next  11/14] i40e: reorder block declarations in debugfs
Date: Fri, 18 Oct 2013 18:13:26 +0400
Message-ID: <52614206.7050404@cogentembedded.com>
References: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com> <1382102598-11343-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, a@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:37550 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab3JROO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 10:14:27 -0400
Received: by mail-lb0-f169.google.com with SMTP id z5so3182042lbh.14
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 07:14:26 -0700 (PDT)
In-Reply-To: <1382102598-11343-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-10-2013 17:23, Jeff Kirsher wrote:

> From: Shannon Nelson <shannon.nelson@intel.com>

> This is a cleanup of the arguments declared at the beginning
> of each function.

    I hope you meant "local variables" because "arguments" are the values 
passed to a function.

> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

WBR, Sergei
