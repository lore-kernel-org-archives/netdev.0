From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: use proper Attribute for Action stats
Date: 23 Mar 2005 19:46:45 -0500
Message-ID: <1111625204.1039.10.camel@jzny.localdomain>
References: <1111624822.1039.7.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1111624822.1039.7.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I should add: Thanks to Andy Furniss <andy.furniss@dsl.pipex.com>
for finding and helping debug this.

cheers,
jamal

On Wed, 2005-03-23 at 19:40, jamal wrote:
> Dave,
> Action stats were being sent on the wrong TLV. Patch attached.
> 
> cheers,
> jamal
