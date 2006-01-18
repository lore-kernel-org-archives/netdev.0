From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [PATCH 5/5] [RFC] Infiniband:
	connection	abstraction
Date: Wed, 18 Jan 2006 10:19:01 -0800
Message-ID: <43CE8695.9080401@ichips.intel.com>
References: <ORSMSX401yEXUIEAOeI00000043@orsmsx401.amr.corp.intel.com>
	<adar775wnfi.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adar775wnfi.fsf@cisco.com>
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

Roland Dreier wrote:
>  > +	UCMA_MAX_BACKLOG	= 128
> 
> Is there any reason that we might want to make this a tunable?  Maybe
> as a module parameter that's writable in sysfs...

There's no reason not to make this tunable.

- Sean
