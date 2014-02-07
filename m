From: srinivas kandagatla <srinivas.kandagatla@st.com>
Subject: Re: [PATCH v1 1/3] net: stmmac:sti: Add STi SOC glue driver.
Date: Fri, 7 Feb 2014 07:54:18 +0000
Message-ID: <52F4912A.4040008@st.com>
References: <1391428787-27143-1-git-send-email-srinivas.kandagatla@st.com>	<1391428868-27245-1-git-send-email-srinivas.kandagatla@st.com>
 <20140206.195342.1998479313077409827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, linux@arm.linux.org.uk,
 kernel@stlinux.com, pawel.moll@arm.com, ijc+devicetree@hellion.org.uk,
 netdev@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-kernel@vger.kernel.org, stuart.menefy@st.com, robh+dt@kernel.org,
 rob@landley.net, galak@codeaurora.org, peppe.cavallaro@st.com,
 linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140206.195342.1998479313077409827.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Thankyou Dave,

On 07/02/14 03:53, David Miller wrote:
> From: <srinivas.kandagatla@st.com>
> Date: Mon, 3 Feb 2014 12:01:08 +0000
> 
>> +	res = platform_get_resource_byname(pdev,
>> +				IORESOURCE_MEM, "sti-ethconf");
> 
> This is not the correct way to format multi-line function calls,
> you'll need to fix this up in this entire series.

I will fix this in next version.


> 
> The arguments on the second and subsequent lines must start at
> the first column after the openning parenthesis of the function
> call.  You must use the appropriate number of both space and
> TAB characters necessary to do so.
> 
> If you're only using TAB characters to indent, you're doing it
> wrong.
> 
> Thank you.
> 
> 

Thanks,
srini
