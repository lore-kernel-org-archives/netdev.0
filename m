From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: stmmac still supporting spear600 ?
Date: Thu, 9 Mar 2017 14:49:27 +0530
Message-ID: <20170309091927.GA3341@vireshk-i7>
References: <20170309093412.33c0277d@free-electrons.com>
 <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Alexandre Torgue <alexandre.torgue@st.com>, netdev@vger.kernel.org,
 Viresh Kumar <vireshk@kernel.org>,
 Shiraz Hashim <shiraz.linux.kernel@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <373e2760-94c5-4349-33aa-158bc8f4b19e@st.com>
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

On 09-03-17, 10:09, Giuseppe CAVALLARO wrote:
> Hello
> 
> We do not test stmmac on this spear board since many years
> and I guess you have to provide parameters from the platform.
> In fact, stmmac is recently tested with DT.
> IIRC, the mac on spear600 could not have the HW cap register
> so it is mandatory to provide all the right parameters and
> configurations for this HW.

Same here, I haven't tested it since many years and trust whatever Giuseppe has
said.

-- 
viresh
