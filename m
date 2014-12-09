From: Flavio Leitner <fbl@redhat.com>
Subject: Re: OVS Kernel Datapath development
Date: Tue, 9 Dec 2014 10:52:18 -0200
Message-ID: <20141209125217.GA20722@t520.home>
References: <CALnjE+rn_Giv+8TM1_E2faBftRkivXMYHcjn-4Eq4Gu15r=CiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755234AbaLINTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 08:19:53 -0500
Content-Disposition: inline
In-Reply-To: <CALnjE+rn_Giv+8TM1_E2faBftRkivXMYHcjn-4Eq4Gu15r=CiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 07, 2014 at 08:47:22PM -0800, Pravin Shelar wrote:
> Since the beginning OVS kernel datapath development is primarily done
> on external OVS repo. Now we have mostly synced upstream and external
> OVS. So we have decided to change this process. New process is as
> follows.
> 
> 1. OVS feature development that involves kernel datapath should be
> done on net-next tree datapath.
> 2. Such feature patch series should be posted on netdev and ovs-dev
> mailing list.
> 3. Once review is done for entire series, kernel and OVS userspace
> patches will be merged in respective repo.
> 4. After the merge developer is suppose to send patches for external
> kernel datapath along with old kernel compatibility code. So that we
> can keep external datapath insync.

This is great! Thanks for changing the development process and
make it official.

Cheers!
fbl
