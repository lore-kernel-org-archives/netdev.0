From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 3/6] net/IB: export ip_dev_find
Date: Mon, 06 Mar 2006 13:31:05 -0800
Message-ID: <adaslpv5kh2.fsf@cisco.com>
References: <ORSMSX4011XvpFVjCRG00000006@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX4011XvpFVjCRG00000006@orsmsx401.amr.corp.intel.com> (Sean
	Hefty's message of "Mon, 6 Mar 2006 11:07:44 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Sean> Export ip_dev_find to allow locating a net_device given an
    Sean> IP address.

My plan is to queue all of this stuff for merging in 2.6.17.

Is there any objection from netdev or openib-general people?

I just looked back, and the original "unexport ip_dev_find()" patch
was a de-Bunk-ing change.  Now that there is a modular user, is there
any problem with re-exporting it?

Thanks,
  Roland
