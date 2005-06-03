From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 13:28:57 -0700
Message-ID: <Pine.CYG.4.58.0506031327370.400@mawilli1-desk2.amr.corp.intel.com>
References: <1117765954.6095.49.camel@localhost.localdomain>
 <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
 <1117824150.6071.34.camel@localhost.localdomain> <20050603.120126.41874584.davem@davemloft.net>
 <1117827650.6071.59.camel@localhost.localdomain> <1117830205.6071.81.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1117830205.6071.81.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 3 Jun 2005, jamal wrote:

>
> Sorry, Its already there as Dave said in his email.
> Look for time_squeeze. Its the column i labeled XXXX below.
>
> -----
> $ cat /proc/net/softnet_stat
> 0000f938 00000000 XXXXXXX 00000000 00000000 00000000 00000000 00000000
> 00000000
> ------


I might not be able to get into the lab today (they keep making me do
work!), but I should be able to pop in Monday and take a look.  Shouldn't
take too long.

Thanks,
Mitch
