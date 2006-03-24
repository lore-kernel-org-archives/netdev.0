From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: Re: [patch 2/6] s390: qeth driver statistics fixes
Date: Fri, 24 Mar 2006 10:06:11 +0100
Message-ID: <20060324100611.5c59e68b@localhost.localdomain>
References: <20060322160339.4e6cf34e@localhost.localdomain>
	<4421FA37.4050703@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751356AbWCXJE5@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4421FA37.4050703@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Mar 2006 20:30:31 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Frank Pavlic wrote:
> > [patch 2/6] s390: qeth driver statistics fixes 
> > 
> > From: Ursula Braun <braunu@de.ibm.com>
> > 	- display "unsigned int" values in /proc/qeth_perf with %u instead of %i
> > 	- omit qdio header length when increasing card->stats.tx_bytes
> > 
> > Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
> 
> applied 2-4
> 
> I am OK with removing tty from network driver (patches 5-6), but they 
> didn't apply
> 
> 

hmm ok , I have built new ones today ...
Let me know if you still run into problems to apply the new two ctc tty removal patches...

Thanks 

Frank
