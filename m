From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Thu, 12 Jun 2008 09:04:39 -0700
Message-ID: <20080612160439.GA13713@synapse.neuralscape.com>
References: <20080610205633.11186.45499.stgit@dale>
	<20080610210918.11186.64253.stgit@dale>
	<484F751F.7030407@trash.net>
	<71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amar.mudrankit@qlogic.com, netdev@vger.kernel.org, rdreier@cisco.com,
	general@lists.openfabrics.org, Patrick McHardy <kaber@trash.net>,
	poornima.kamath@qlogic.com
To: Ramachandra K <ariston@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 12, 2008 at 09:20:27PM +0530, Ramachandra K wrote:
> <snip>
> 
> >> +# An interface can be deleted by echoing the name of the interface to be
> >> deleted
> >> +# to delete_vnic file
> >> +echo -n veth1 > /sys/class/infiniband_qlgc_vnic/interfaces/delete_vnic
> >
> >
> > This clearly shows the advantage of being able to use echo
> > for configuration.
> 
> >From this statement, I thought you agreed with the advantage of echo for
> configuration.
> 
> Regards,
> Ram
Hi Ram,
I believe that was Roland's comment, not Patrick's.
Karen
-- 
 Karen Shaeffer
 Neuralscape, Palo Alto, Ca. 94306
 shaeffer@neuralscape.com  http://www.neuralscape.com
