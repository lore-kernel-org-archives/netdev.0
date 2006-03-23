From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2/6] s390: qeth driver statistics fixes
Date: Wed, 22 Mar 2006 20:30:31 -0500
Message-ID: <4421FA37.4050703@pobox.com>
References: <20060322160339.4e6cf34e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932472AbWCWBah@vger.kernel.org>
To: Frank Pavlic <fpavlic@de.ibm.com>
In-Reply-To: <20060322160339.4e6cf34e@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic wrote:
> [patch 2/6] s390: qeth driver statistics fixes 
> 
> From: Ursula Braun <braunu@de.ibm.com>
> 	- display "unsigned int" values in /proc/qeth_perf with %u instead of %i
> 	- omit qdio header length when increasing card->stats.tx_bytes
> 
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

applied 2-4

I am OK with removing tty from network driver (patches 5-6), but they 
didn't apply
