From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 01/16] i40e: support VF link state ndo
Date: Mon, 17 Mar 2014 23:24:17 +0200
Message-ID: <CAJZOPZLrwg2sMnhQZZhpjWdqjBEBuWujv0Uy9q-_bViK5j46zg@mail.gmail.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395060316-16897-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:65059 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaCQVYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:24:18 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so6094578pdj.23
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 14:24:17 -0700 (PDT)
In-Reply-To: <1395060316-16897-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 2:45 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
> This netdev op allows the PF driver to control the virtual link state of
> the VF devices. This can be used to deny naughty VF drivers access to the wire,

Does this denial exists in the patch or the current code? where?

Or.
