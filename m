From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 00/11] ibmvnic: Driver updates
Date: Fri, 26 May 2017 15:33:02 -0400 (EDT)
Message-ID: <20170526.153302.1257010467189922920.davem@redhat.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52374 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753852AbdEZTdE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 15:33:04 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Fri, 26 May 2017 10:30:07 -0400

> This set of patches implements several updates to the ibmvnic driver
> to fix issues that have been found in testing. Most of the updates
> invovle updating queue handling during driver close and reset
> operations.

Series applied, thanks.
