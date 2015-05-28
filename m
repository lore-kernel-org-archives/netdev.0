From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 07/14] i40e: Remove unnecessary pf members
Date: Thu, 28 May 2015 15:56:41 +0300
Message-ID: <CAJ3xEMh-c=sToPDiyc+G5_Pofrvebr=Zh7Fro=e6UoJq9mbb+Q@mail.gmail.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1432812339-17129-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33072 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbbE1M4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 08:56:43 -0400
Received: by obbnx5 with SMTP id nx5so31717691obb.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 05:56:42 -0700 (PDT)
In-Reply-To: <1432812339-17129-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 2:25 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Anjali Singhai Jain <anjali.singhai@intel.com>
>
> We can use the stat index macro directly, a variable is not required.

Sorry, but while attempting to look on the patch, I wasn't able to
decipher the change-log nor to somehow
relate it  to the patch title. Can you make it a litter clearer, by
"pf members" are we talking on SRIOV PFs or VFs or none or both?
